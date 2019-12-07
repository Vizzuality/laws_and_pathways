module CCLOW
  class CCLOWController < ApplicationController
    include BaseAuth
    include StaticPagesController

    layout 'cclow'

    protected

    def add_breadcrumb(title, path)
      @breadcrumb = (@breadcrumb || []).push(Site::Breadcrumb.new(title, path))
    end
  end
end
