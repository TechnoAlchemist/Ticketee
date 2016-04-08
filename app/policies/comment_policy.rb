class CommentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.try(:admin?) || record.project.has_manager?(user) || 
      record.project.has_editor?(user)
  end
end
