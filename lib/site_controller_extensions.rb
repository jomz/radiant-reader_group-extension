module SiteControllerExtensions
  
  def self.included(base)
    base.class_eval {
      # to control access without ruining the cache we have set Page.cache? = false
      # for any page that has a group association. This should  prevent the relatively 
      # few private pages from being cached, and it remains safe to return any cached
      # page we find.
      
      def find_page_with_group_check(url)
        page = find_page_without_group_check(url)
        raise ReaderGroup::PermissionDenied if page && !page.visible_to?(current_reader)
        page
      end
        
      def show_page_with_group_check
        show_page_without_group_check
      rescue ReaderGroup::PermissionDenied
        if current_reader
          flash[:error] = t("page_private")
          redirect_to reader_permission_denied_url
        else
          flash[:explanation] = t('page_not_public')
          flash[:error] = "Please log in."
          store_location
          redirect_to reader_login_url
        end
      end
        
      alias_method_chain :find_page, :group_check
      alias_method_chain :show_page, :group_check
    }
  end
end



