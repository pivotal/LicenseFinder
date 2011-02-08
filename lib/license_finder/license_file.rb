module LicenseFinder
  class LicenseFile < FileParser
    MIT_LICENSE_TEXT = (LicenseFinder::ROOT_PATH + 'templates/MIT-body').read
    MIT_HEADER_REGEX = /The MIT License/
    MIT_DISCLAIMER_REGEX = /THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT\. IN NO EVENT SHALL ((\w+ ){2,8})BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE\./
    
    def body_type
      mit_license_body? ? 'mit' : 'other'
    end
    
    def header_type
      mit_license_header? ? 'mit' : 'other'
    end
    
    def disclaimer_of_liability
      mit_disclaimer_of_liability? ? "mit: #{@mit_authors}" : 'other'
    end

    def mit_license_body?
      !!on_single_line(text).index(on_single_line(MIT_LICENSE_TEXT))
    end
    
    def mit_license_header?
      header = text.split("\n").first
      header && header.strip =~ MIT_HEADER_REGEX
    end
    
    def mit_disclaimer_of_liability?
      result = !!(on_single_line(text) =~ MIT_DISCLAIMER_REGEX)
      @mit_authors = ($1 || '').strip
      result
    end

    def to_hash
      h = { 
        'file_name' => file_path, 
        'header_type' => header_type,
        'body_type' => body_type,
        'disclaimer_of_liability' => disclaimer_of_liability
      }
      h['text'] = text if include_license_text?
      h
    end

    attr_writer :include_license_text

    private

    def include_license_text?
      @include_license_text
    end
  end
end
