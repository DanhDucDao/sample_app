class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: to_down_case(params[:session][:email])
    if user&.authenticate(params[:session][:password])
      accept_user user
    else
      flash.now[:danger] = t ".invalid"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end

  private
  def to_down_case str
    str.downcase
  end

  def accept_user user
    log_in user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
    redirect_to user
  end
end
