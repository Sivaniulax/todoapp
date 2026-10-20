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
    { title: "Buy groceries", priority: :low, category: home, completed: true },
    { title: "Read about React hooks", description: "useState, useEffect, useReducer, custom hooks" }
  ])
end

puts "Demo user: demo@todoapp.dev / password123"
