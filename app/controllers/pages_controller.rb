class PagesController < ApplicationController

	def home
	end

	def troup_history
  end

  def galery
  end

	def video
	end

  def history
  end

	def partners
	end

  def contacts
  end

  def sitemap
    respond_to do |format|
      format.xml { render file: 'public/sitemaps/sitemap.xml' }
      format.html { redirect_to root_url }
    end
  end

  def robots
  end
end
