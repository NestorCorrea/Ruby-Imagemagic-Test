class GeneratorsController < ApplicationController
  # GET /generators
  # GET /generators.json

  include GeneratorsHelper

  def index
    @generators = Generator.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @generators }
    end
  end

  # GET /generators/1
  # GET /generators/1.json
  def show
    @generator = Generator.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @generator }
    end

    init_wraps
  end

  # GET /generators/new
  # GET /generators/new.json
  def new
    @generator = Generator.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @generator }
    end
  end

  # GET /generators/1/edit
  def edit
    @generator = Generator.find(params[:id])
  end

  # POST /generators
  # POST /generators.json
  def create
    @generator = Generator.new(params[:generator])

    respond_to do |format|
      if @generator.save
        format.html { redirect_to @generator, notice: 'Generator was successfully created.' }
        format.json { render json: @generator, status: :created, location: @generator }
      else
        format.html { render action: "new" }
        format.json { render json: @generator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /generators/1
  # PUT /generators/1.json
  def update
    @generator = Generator.find(params[:id])

    respond_to do |format|
      if @generator.update_attributes(params[:generator])
        format.html { redirect_to @generator, notice: 'Generator was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @generator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /generators/1
  # DELETE /generators/1.json
  def destroy
    @generator = Generator.find(params[:id])
    @generator.destroy

    respond_to do |format|
      format.html { redirect_to generators_url }
      format.json { head :no_content }
    end
  end
end
