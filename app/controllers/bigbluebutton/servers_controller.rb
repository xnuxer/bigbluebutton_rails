class Bigbluebutton::ServersController < ApplicationController

  respond_to :html
  respond_to :json, :only => [:index, :show, :new, :create, :update, :destroy, :activity, :rooms]
  before_filter :find_server, :only => [:show, :edit, :activity, :update, :destroy, :rooms]

  def index
    respond_with(@servers = BigbluebuttonServer.all)
  end

  def show
    respond_with(@server)
  end

  def new
    respond_with(@server = BigbluebuttonServer.new)
  end

  def edit
    respond_with(@server)
  end

  def activity
    error = false
    begin
      @server.fetch_meetings
      @server.meetings.each do |meeting|
        meeting.fetch_meeting_info
      end
    rescue BigBlueButton::BigBlueButtonException => e
      error = true
      message = e.to_s
    end

    # update_list works only for html
    if params[:update_list] && (params[:format].nil? || params[:format].to_s == "html")
      render :partial => 'activity_list', :locals => { :server => @server }
      return
    end

    respond_with @server.meetings do |format|
      # we return/render the fetched meetings even in case of error
      # but we set the error message in the response
      if error
        flash[:error] = message
        format.html { render :activity }
        format.json {
          array = @server.meetings
          array.insert(0, { :message => message })
          render :json => array, :status => :error
        }
      else
        format.html
        format.json
      end
    end
  end

  def create
    @server = BigbluebuttonServer.new(params[:bigbluebutton_server])

    respond_with @server do |format|
      if @server.save
        format.html {
          message = t('bigbluebutton_rails.servers.notice.create.success')
          redirect_to(@server, :notice => message)
        }
        format.json { render :json => @server, :status => :created }
      else
        format.html { render :new }
        format.json { render :json => @server.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_with @server do |format|
      if @server.update_attributes(params[:bigbluebutton_server])
        format.html {
          message = t('bigbluebutton_rails.servers.notice.update.success')
          redirect_to(@server, :notice => message)
        }
        format.json { head :ok }
      else
        format.html { render :edit }
        format.json { render :json => @server.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @server.destroy

    respond_with do |format|
      format.html { redirect_to(bigbluebutton_servers_url) }
      format.json { head :ok }
    end
  end

  def rooms
    respond_with(@rooms = @server.rooms)
  end

  protected

  def find_server
    @server = BigbluebuttonServer.find_by_param(params[:id])
  end

end
