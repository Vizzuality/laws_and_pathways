module Api
  class Filters
    # rubocop:disable Security/Eval
    def initialize(class_name, filter_params)
      @class = eval(class_name)
      @filter_params = filter_params
      @list = nil
    end
    # rubocop:enable Security/Eval

    def call
      filter
    end

    private

    def filter
      return @class.all if @filter_params.empty?

      @list = filter_by_ids || @class.all
      filter_by_region
      @list
    end

    def filter_by_ids
      return nil if @filter_params[:ids].nil? && @filter_params[:fromDate].nil?

      if @filter_params[:fromDate].present?
        @list = @class.where('updated_at >= ?', @filter_params[:fromDate])
      else
        ids = @filter_params[:ids].split(',').map(&:to_i)
        @list = @class.where(id: ids)
      end
    end

    def filter_by_region
      return nil if @filter_params[:region].nil? && @filter_params[:geography].nil?

      @list = if @filter_params[:region].present? && @filter_params[:geography].present?
                @list.includes(:geography)
                  .where(geographies: {region: @filter_params[:region]})
                  .or(@list.includes(:geography).where(geographies: {id: @filter_params[:geography]}))
              elsif @filter_params[:region].present?
                @list.includes(:geography).where(geographies: {region: @filter_params[:region]})
              else
                @list.includes(:geography).where(geographies: {id: @filter_params[:geography]})
              end
    end
  end
end
