class Ticket < ActiveRecord::Base
  attr_accessor :tag_names

  belongs_to :project
  belongs_to :author, class_name: "User"
  belongs_to :state
  has_many :attachments, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :tags, uniq: true
  
  accepts_nested_attributes_for :attachments, reject_if: :all_blank

  validates :name, presence: true
  validates :description, presence: true, length: { minimum: 10 }

  before_create :assign_default_state

  
  def self.search(query)
    query.split(" ").collect do |query|
      query.split(":")
    end.inject(self) do |klass, (name, q)|
      association = klass.reflect_on_association(name.to_sym)
      unless association
        name = name.pluralize
        association = klass.reflect_on_association(name.to_sym)
      end

      association_table = association.klass.arel_table

      if [:has_and_belongs_to_many, :belongs_to].include?(association.macro)
        joins(name.to_sym).where(association_table["name"].eq(q))
      else
        all
      end
    end
  end

  def tag_names=(names)
    @tag_names = names
    names.split.each do |name|
      self.tags << Tag.where(name: name).first_or_create 
    end
  end

  private

  def assign_default_state
    self.state ||= State.default
  end
end
