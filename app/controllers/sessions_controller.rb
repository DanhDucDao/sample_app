class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: to_down_case(params[:session][:email])
    if user&.authenticate(params[:session][:password])
      log_in user
      redirect_to user
    else
      flash.now[:danger] = t ".invalid"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end

  private
  def to_down_case str
    str.downcase
  end
end
