module HtmlFormatter
  class ElixirIndenter
    INDENT_KEYWORDS = %w[ else ]
    OUTDENT_KEYWORDS = %w[ else end ]
    ELIXIR_INDENT  = %r{
      ^ ( #{INDENT_KEYWORDS.join("|")} )\b
      | ^ ( \w+\s*=\s*form\_for )
      | ( -\> | do ) $
    }xo
    ELIXIR_OUTDENT = %r{ ^ ( #{OUTDENT_KEYWORDS.join("|")} | \} ) \b }xo

    def outdent?(lines)
      lines.first =~ ELIXIR_OUTDENT
    end

    def indent?(lines)
      lines.join("\n") =~ ELIXIR_INDENT
    end
  end
end
