require 'spec_helper'

describe OGP::OpenGraph do
  describe '#initialize' do
    context 'with strictly the required attributes' do
      it 'should create a proper OpenGraph object' do
        content = File.read("#{File.dirname(__FILE__)}/../fixtures/required_attributes.html")
        open_graph = OGP::OpenGraph.new(content)

        expect(open_graph.title).to eql('The Rock')
        expect(open_graph.type).to eql('video.movie')
        expect(open_graph.url).to eql('http://www.imdb.com/title/tt0117500/')
        expect(open_graph.image.url).to eql('http://ia.media-imdb.com/images/rock.jpg')
      end
    end

    context 'with missing one of the required attributes' do
      let(:content) { File.read("#{File.dirname(__FILE__)}/../fixtures/missing_required_attributes.html") }
      let(:open_graph) { OGP::OpenGraph.new(content) }

      it 'should not raise an error' do
        expect { open_graph }.not_to raise_error
      end

      it 'should return the missing attributes as errors' do
        expect(open_graph.valid?).to be(false)
        expect(open_graph.errors).to eql([
          { image: 'attribute is missing' }
        ])
      end

      it 'should return the attributes found' do
        expect(open_graph.url).to eql('http://www.imdb.com/title/tt0117500/')
      end
    end

    context 'with nil source' do
      it 'should raise an error' do
        expect { OGP::OpenGraph.new(nil) }.to raise_error(ArgumentError)
      end
    end

    context 'with empty source' do
      it 'should raise an error' do
        expect { OGP::OpenGraph.new('') }.to raise_error(ArgumentError)
      end
    end

    context 'with malformed source' do
      it 'should raise an error' do
        expect { OGP::OpenGraph.new('Lorem ipsum dolor sit amet, consectetur adipiscing elit.') }.to raise_error(OGP::MalformedSourceError)
      end
    end

    context 'with optional attributes' do
      it 'should create a proper OpenGraph object' do
        content = File.read("#{File.dirname(__FILE__)}/../fixtures/optional_attributes.html")
        open_graph = OGP::OpenGraph.new(content)

        expect(open_graph.audios[0].url).to eql('http://example.com/bond/theme.mp3')
        expect(open_graph.description).to eql('Sean Connery found fame and fortune as the suave, sophisticated British agent, James Bond.')
        expect(open_graph.determiner).to eql('the')
        expect(open_graph.locales).to match_array(%w(en_GB fr_FR es_ES))
        expect(open_graph.site_name).to eql('IMDb')
        expect(open_graph.videos[0].url).to eql('http://example.com/bond/trailer.swf')
      end
    end

    context 'with image structured attributes' do
      it 'should create a proper OpenGraph object' do
        content = File.read("#{File.dirname(__FILE__)}/../fixtures/image_structured_attributes.html")
        open_graph = OGP::OpenGraph.new(content)

        expect(open_graph.image.url).to eql('http://example.com/ogp.jpg')
        expect(open_graph.image.secure_url).to eql('https://secure.example.com/ogp.jpg')
        expect(open_graph.image.type).to eql('image/jpeg')
        expect(open_graph.image.width).to eql('400')
        expect(open_graph.image.height).to eql('300')
        expect(open_graph.image.alt).to eql('A shiny red apple with a bite taken out')
      end
    end

    context 'with audio structured attributes' do
      it 'should create a proper OpenGraph object' do
        content = File.read("#{File.dirname(__FILE__)}/../fixtures/audio_structured_attributes.html")
        open_graph = OGP::OpenGraph.new(content)

        expect(open_graph.audios[0].url).to eql('http://example.com/sound.ogg')
        expect(open_graph.audios[0].secure_url).to eql('https://secure.example.com/sound.ogg')
        expect(open_graph.audios[0].type).to eql('audio/ogg')
      end
    end

    context 'with video structured attributes' do
      it 'should create a proper OpenGraph object' do
        content = File.read("#{File.dirname(__FILE__)}/../fixtures/video_structured_attributes.html")
        open_graph = OGP::OpenGraph.new(content)

        expect(open_graph.videos[0].url).to eql('http://example.com/movie.swf')
        expect(open_graph.videos[0].secure_url).to eql('https://secure.example.com/movie.swf')
        expect(open_graph.videos[0].type).to eql('application/x-shockwave-flash')
        expect(open_graph.videos[0].width).to eql('400')
        expect(open_graph.videos[0].height).to eql('300')
      end
    end

    context 'with multiples image attributes' do
      it 'should create a proper OpenGraph object' do
        content = File.read("#{File.dirname(__FILE__)}/../fixtures/multiple_images_attributes.html")
        open_graph = OGP::OpenGraph.new(content)

        expect(open_graph.images[0].url).to eql('http://example.com/ogp1.jpg')
        expect(open_graph.images[0].type).to eql('image/jpeg')
        expect(open_graph.images[0].width).to eql('400')
        expect(open_graph.images[0].height).to eql('300')
        expect(open_graph.images[1].url).to eql('http://example.com/ogp2.jpg')
        expect(open_graph.images[1].type).to eql('image/jpeg')
        expect(open_graph.images[1].width).to eql('600')
        expect(open_graph.images[1].height).to eql('500')
      end
    end
  end
end
