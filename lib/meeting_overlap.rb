# frozen_string_literal: true

require "date"
require "tzinfo"

module MeetingOverlap
    module_function

    def working_hours_utc(zone:, date:, start: "09:00", finish: "17:00")
        timezone = TZInfo::Timezone.get(zone)
        [start, finish].map do |time|
            hour, minute = time.split(":").map(&:to_i)
            timezone.local_time(date.year, date.month, date.day, hour, minute).getutc
        end
    end

    def online_windows(team, date)
        shifts = team.map do |member|
            start, finish = working_hours_utc(zone: member[:zone], date: date)
            { name: member[:name], start: start, finish: finish}
        end
        edges = shifts.flat_map { |shift| [shift[:start], shift[:finish]] }.uniq.sort

        edges.each_cons(2).filter_map do |from, to|
            online = shifts.select { |shift| shift[:start] <= from && shift[:finish] >= to }.map { |shift| shift[:name] }
            { start: from.strftime("%H:%M"), finish: to.strftime("%H:%M"), online: online } unless online.empty?
        end
    end

    def best_window(team, date)
        online_windows(team, date).max_by { |window| window[:online].size }
    end
end