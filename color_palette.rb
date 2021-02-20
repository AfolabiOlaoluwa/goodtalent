require 'pry'

class ColorPalette
  class << self
    NUMBER_OF_COLORS =  2
    MAX_VALUE_OF_COLOR = 255
    SIX_DIGIT_COLOUR_FORMAT = '%06x'
    WHITE_COLOR = 0xffffff
    HEX_BASE = 16
    COLOR_LUMINOSITY = 1
    HALF_OF_COLOR_LUMINOSITY = 0.5

    def generate_unique_color(existing_colors)
      new_color = SIX_DIGIT_COLOUR_FORMAT % (rand * WHITE_COLOR)
      return self.generate_unique_color(existing_colors) if existing_colors.has_key?(new_color.to_sym)

      new_color
    end

    def color_mixer(first_color, second_color)
      first_processed_color = process_color_to_cmyk(first_color)
      second_processed_color = process_color_to_cmyk(second_color)
      color = cmyk_aggregator(first_processed_color, second_processed_color)
      process_color_to_rgb(color)
    end

    private

    def cmyk_aggregator(first_color, second_color)
      [:c, :m, :y, :k, :a].each_with_object({}) do |key, hsh|
        hsh[key] = (first_color[key] + second_color[key]) / NUMBER_OF_COLORS
      end
    end

    def process_color_to_rgb(color)
      key = color[:k]
      r = color[:c] * (COLOR_LUMINOSITY.to_f - key) + key
      g = color[:m] * (COLOR_LUMINOSITY.to_f - key) + key
      b = color[:y] * (COLOR_LUMINOSITY.to_f - key) + key
      r = ((COLOR_LUMINOSITY.to_f - r) * MAX_VALUE_OF_COLOR.to_f + HALF_OF_COLOR_LUMINOSITY).round
      g = ((COLOR_LUMINOSITY.to_f - g) * MAX_VALUE_OF_COLOR.to_f + HALF_OF_COLOR_LUMINOSITY).round
      b = ((COLOR_LUMINOSITY.to_f - b) * MAX_VALUE_OF_COLOR.to_f + HALF_OF_COLOR_LUMINOSITY).round
      [r, g, b].map { |pigment| pigment.to_i.to_s(HEX_BASE) }.join("")
    end

    def process_color_to_cmyk(color)
      rgba = color.gsub('#', '').scan(/../).map { |color| color.hex }
      cyan, magenta, yellow = rgba.map { |pigment| MAX_VALUE_OF_COLOR - pigment }
      black = [cyan, magenta, yellow].min.to_f
      black_complement = MAX_VALUE_OF_COLOR - black

      c = (cyan - black) / black_complement
      m = (magenta - black) / black_complement
      y = (yellow - black) / black_complement

      { c: c, m: m, y: y, k: black / MAX_VALUE_OF_COLOR, a: rgba[3] || 1 }
    end
  end
end