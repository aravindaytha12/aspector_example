class PagesController < ApplicationController
  def index
    PagesController.index_test #class_method
    protected_new #protected_method
    private_new #private_method

    @hobby_posts = Post.by_branch('hobby').limit(8)
    @study_posts = Post.by_branch('study').limit(8)
    @team_posts = Post.by_branch('team').limit(8)
    @contacts = user_signed_in? ? current_user.all_active_contacts : ''
  end

  def self.index_test
    puts "class_method 11111111111111111111111111111"
  end

  private
  def private_new
    puts "private 333333333333333333333333333333"
  end

  protected
  def protected_new
    puts "protected 222222222222222222222222222222"
  end

end

method_names_arr = (PagesController.instance_methods(false).to_a + PagesController.private_instance_methods(false).to_a + PagesController.action_methods.to_a)

method_names_arr.map!(&:to_sym).uniq
LoggingAspect.apply(PagesController, methods: method_names_arr)