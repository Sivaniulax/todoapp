threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

port ENV.fetch("PORT", 3000)

plugin :tmp_restart
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

# Run Solid Queue's supervisor inside Puma so one Render service covers both
# web and jobs. Its supervisor forks, which Windows cannot do, so the plugin
# is skipped there. Set SOLID_QUEUE_IN_PUMA=false to run `bin/jobs` instead.
if !Gem.win_platform? && ENV["SOLID_QUEUE_IN_PUMA"] != "false"
  plugin :solid_queue
end
