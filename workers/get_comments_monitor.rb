# frozen_string_literal: true

module GetComments
  # Infrastructure to clone while yielding progress
  module GetCommentsMonitor
    CLONE_PROGRESS = {
      'STARTED'        => 5,
      'YOUTUBE_START'  => 10,
      'YOUTUBE_FINISH' => 90,
      'FINISHED'       => 100
    }.freeze

    def self.starting_percent
      percent('STARTED').to_s
    end

    def self.finished_percent
      percent('FINISHED').to_s
    end

    def self.progress(step, comments_completed, total_comments)
      start = percent("#{step}_START")
      finish = percent("#{step}_FINISH")

      progress = start + (comments_completed * (finish - start) / total_comments)
      progress < finish ? progress.to_s : finish.to_s
    end

    def self.percent(stage)
      CLONE_PROGRESS[stage]
    end

    def self.first_word_of(line)
      line.match(/^[A-Za-z]+/).to_s
    end
  end
end
