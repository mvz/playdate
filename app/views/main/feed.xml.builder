xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
# FIXME: xml.instruct! "xml-stylesheet", :type => "text/css", :href => stylesheet_path('feed')
xml.feed 'xml:lang' => 'en-US', 'xmlns' => 'http://www.w3.org/2005/Atom' do
  xml.title @feed_title
  xml.id 'tag:www.matijs.org,2007:/apps/playdate'
  xml.generator 'Playdate', uri: 'http://www.matijs.net/', version: '1.0'
  xml.link 'rel' => 'self', 'type' => 'application/atom+xml', 'href' => url_for(only_path: false)
  xml.link 'rel' => 'alternate', 'type' => 'text/html', 'href' => @link

  unless @updated_at.nil?
    xml.updated @updated_at.xmlschema

    xml.entry do
      xml.author { xml.name 'Playdate!'; xml.email 'playdate@matijs.net' }
      xml.id "tag:www.matijs.org,#{@updated_at.strftime('%Y-%m-%d')}:/apps/playdate"

      xml.updated @updated_at.xmlschema
      title = "Updates voor #{@updated_at.strftime('%d/%m/%Y')}"
      xml.title title, 'type' => 'html'

      xml.content @content, 'type' => 'html'
    end
  end
end
