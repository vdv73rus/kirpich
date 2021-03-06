module Kirpich::Providers
  class GoogleVideo
    class << self
      def search(q, page = 0)
        _search(q, page)
      end

      def search_xxx(q, page = 0)
        q ||= 'girls'
        q += [' soft', ' softcore', ' sensuality'].sample

        _search(q, page)
      end

      def _search(q, page)
        q = _clean(q)

        params = _search_params(q, page)
        result = _send_request(params)

        return unless _result_valid?(result)

        url = result['responseData']['results'].first['url']
      end

      def _send_request(params)
        response = Faraday.get('http://ajax.googleapis.com/ajax/services/search/video', params)
        result = JSON.parse response.body
        Kirpich.logger.info result

        result
      rescue RuntimeError => e
        Kirpich.logger.error e
        nil
      end

      def _result_valid?(result)
        result.key?('responseData') && result['responseData'].key?('results') && result['responseData']['results'].any?
      end

      def _search_params(q, page)
        params = { q: q, rsz: '1', v: '1.0'}
        params[:start] = page if page > 0

        params
      end

      def _clean(text)
        text.gsub(/(покажи|нам)/, '')
      end
    end
  end
end
