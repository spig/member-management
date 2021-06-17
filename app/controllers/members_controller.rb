require 'fastercsv'

class MembersController < ApplicationController
  # GET /members
  # GET /members.xml
  def index
    @members = Member.find(:all, :order => 'keep desc, deleted asc, new desc, printed_name')

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @members.to_xml }
      format.xls do
        stream_xls do |xls|
          xls << ["name","phone","address"]
          members = Member.find(:all, :conditions => 'keep = 1 and deleted = 0', :order => 'printed_name')
          members.each do |m|
            xls << [m.printed_name, m.phone, m.printed_address]
          end
        end
      end
    end
  end
  
  # GET /members/1
  # GET /members/1.xml
  def show
    @member = Member.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @member.to_xml }
    end
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1;edit
  def edit
    @member = Member.find(params[:id])
  end

  # POST /members
  # POST /members.xml
  def create
    @member = Member.new(params[:member])
    @member.new = false

    respond_to do |format|
      if @member.save
        flash[:notice] = 'Member was successfully created.'
        format.html { redirect_to members_url(@member) }
        format.xml  { head :created, :location => member_url(@member) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @member.errors.to_xml }
      end
    end
  end

  # PUT /members/1
  # PUT /members/1.xml
  def update
    @member = Member.find(params[:id])
    @member.new = false

    respond_to do |format|
      if @member.update_attributes(params[:member])
        flash[:notice] = 'Member was successfully updated.'
        format.html { redirect_to members_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @member.errors.to_xml }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.xml
  def destroy
    @member = Member.find(params[:id])
    @member.deleted = true
    @member.save

    respond_to do |format|
      format.html { redirect_to members_url }
      format.xml  { head :ok }
    end
  end
  
  private
  
    def stream_xls
      filename = "prairie_first_ward_directory.csv"    
      
      #this is required if you want this to work with IE        
      if request.env['HTTP_USER_AGENT'] =~ /msie/i
        headers['Pragma'] = 'public'
        headers["Content-type"] = "text/plain" 
        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
        headers['Expires'] = "0" 
      else
        headers["Content-Type"] ||= 'application/vnd.ms-excel'
        headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
      end
      
      render :text => Proc.new { |response, output|
        xls = FasterCSV.new(output, :row_sep => "\r\n")
        yield xls
      }
    end
  
    def send_csv
    end
    
end
