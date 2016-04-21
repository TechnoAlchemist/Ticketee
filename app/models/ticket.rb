class Ticket < ActiveRecord::Base
  attr_accessor :tag_names

  belongs_to :project
  belongs_to :author, class_name: "User"
  belongs_to :state
  has_many :attachments, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :tags, uniq: true
  has_and_belongs_to_many :watchers, join_table: "ticket_watchers",
    class_name: "User", uniq: true
    
  accepts_nested_attributes_for :attachments, reject_if: :all_blank

  validates :name, presence: true
  validates :description, presence: true, length: { minimum: 10 }

  before_create :assign_default_state
  after_create :author_watches_me

  
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

  def author_watches_me
    if author.present? && !self.watchers.include?(author)
      self.watchers << author
    end
  end
end
