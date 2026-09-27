# meeting-overlap

Find when teammates in different time zones are online at the same time.

## Requirements

- Ruby 3.4.6, pinned in `.ruby-version` (rbenv and similar version managers switch to it automatically)
- Bundler

## Setup

```bash
bundle install
```

## Running the tests

```bash
bundle exec rspec
```

## Usage

```ruby
require_relative "lib/meeting_overlap"

team = [
    { name: "Accra", zone: "Africa/Accra" },
    { name: "Toronto", zone: "America/Toronto" }
]

MeetingOverlap.best_window(team, Date.new(2026, 10, 5))
# => {start: "13:00", finish: "17:00", online: ["Accra", "Toronto"]}
```

Working hours default to 09:00-17:00 local time. Times in the results are UTC.

## Reports

`reports/` holds the team's meeting overlap report.
