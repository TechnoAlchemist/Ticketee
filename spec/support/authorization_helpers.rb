module AuthorizationHelpers
  def assign_role!(user, role, project)
    Role.where(user: user, role: role, project: project).delete_all
    Role.create!(user: user, role: role, project: project)
  end

  def clear_roles(*args)
    args.each {|arg| arg.roles.delete_all}
  end
end

RSpec.configure do |c|
  c.include AuthorizationHelpers
end