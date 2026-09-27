# frozen_string_literal: true

require_relative "../lib/meeting_overlap"

RSpec.describe MeetingOverlap do
    let(:date) { Date.new(2026, 10, 5) }
    let(:team) do
        [
            { name: "Manila", zone: "Asia/Manila" },
            { name: "Bangalore", zone: "Asia/Kolkata" },
            { name: "Nairobi", zone: "Africa/Nairobi" },
            { name: "Berlin", zone: "Europe/Berlin" },
            { name: "Accra", zone: "Africa/Accra" },
            { name: "Sao Paulo", zone: "America/Sao_Paulo" },
            { name: "Toronto", zone: "America/Toronto" }
        ]
    end

    describe ".working_hours_utc" do
        it "handles Bangalore's half-hour offset" do
            start, finish = described_class.working_hours_utc(zone: "Asia/Kolkata", date: date)
            expect([start.strftime("%H:%M"), finish.strftime("%H:%M")]).to eq(["03:30", "11:30"])
        end

        it "uses Berlin summer time in early October" do
            start, _finish = described_class.working_hours_utc(zone: "Europe/Berlin", date: date)
            expect(start.strftime("%H:%M")).to eq("07:00")
        end
    end

    describe ".online_windows" do
        it "finds no hour when all seven cities are online" do
            windows = described_class.online_windows(team, date)
            expect(windows.map { |window| window[:online].size }.max).to be < team.size
        end

        it "never has Manila and Toronto online together" do
            windows = described_class.online_windows(team, date)
            together = windows.select { |window| window[:online].include?("Manila")  && window[:online].include?("Toronto") }
            expect(together).to be_empty
        end
    end

    describe ".best_window" do
        it "is 13:00-14:00 UTC with five cities online" do
            expect(described_class.best_window(team, date)).to eq(
                start: "13:00",
                finish: "14:00",
                online: ["Nairobi", "Berlin", "Accra", "Sao Paulo", "Toronto"]
            )
        end
    end
end

