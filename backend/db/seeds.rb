# Idempotent seeds: safe to run on every deploy (bin/render-build.sh does).

if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?
  admin = User.find_or_initialize_by(email: ENV["ADMIN_EMAIL"].strip.downcase)
  admin.update!(name: "Admin", password: ENV["ADMIN_PASSWORD"], role: :admin)
  puts "Admin ready: #{admin.email}"
end

return unless Rails.env.development?

demo = User.find_or_create_by!(email: "demo@todoapp.dev") do |user|
  user.name = "Demo User"
  user.password = "password123"
end

work = demo.categories.find_or_create_by!(name: "Work") { |c| c.color = "#6366f1" }
home = demo.categories.find_or_create_by!(name: "Home") { |c| c.color = "#10b981" }

if demo.todos.none?
  demo.todos.create!([
    { title: "Learn ActiveRecord scopes", priority: :high, category: work, due_date: Date.current + 1 },
    { title: "Write request specs", priority: :medium, category: work, due_date: Date.current - 2 },
    { title: "Deploy to Render", priority: :high, category: work },
    { title: "Buy groceries", priority: :low, category: home, status: "completed" },
    { title: "Read about React hooks", description: "useState, useEffect, useReducer, custom hooks" }
  ])

  # One of them is already underway, so the status tabs have something in them.
  demo.todos.find_by(title: "Deploy to Render")&.start!

  # Tags are created on demand through the Taggable concern.
  demo.todos.find_by(title: "Learn ActiveRecord scopes")&.update!(tag_names: %w[learning rails])
  demo.todos.find_by(title: "Deploy to Render")&.update!(tag_names: %w[ops urgent])
  demo.todos.find_by(title: "Write request specs")&.update!(tag_names: %w[rails])

  # One todo in the trash, so GET /api/v1/todos/trash has something to show.
  demo.todos.create!(title: "An idea I abandoned", priority: :low).trash!

  # Something due today, so DailyDigestJob has work to do.
  demo.todos.create!(title: "Send the daily digest", priority: :medium, due_date: Date.current)
end

puts "Demo user: demo@todoapp.dev / password123"
