require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe GoogleStaticMapsHelper::Map do
  @@require_options = {
    :size => '800x600',
    :key => 'MY_GOOGLE_KEY',
    :sensor => false
  }

  describe "initialize" do
    @@require_options.each_key do |key|
      it "should raise OptionMissing if #{key} is not given" do
        option_with_missing_option = @@require_options.dup
        option_with_missing_option.delete(key)
        lambda {GoogleStaticMapsHelper::Map.new(option_with_missing_option)}.should raise_error(GoogleStaticMapsHelper::Map::OptionMissing)
      end
    end
  end
end
