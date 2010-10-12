# Ruby 1.9 Compatibility Fix - the below isAlphanum uses Fixnum#ord to be compatible with Ruby 1.9 and 1.8.7
# Fixnum#ord is not found by default in 1.8.6, so monkey patch it in:
if RUBY_VERSION == '1.8.6'
  class Fixnum; def ord; return self; end; end
end

module Palmade::AssetPackager
  class Jsmin

    EOF = -1
    
    class << self
      def minify(source)
        self.new.minify(source)
      end
    end

    def initialize
      @the_a = ""
      @the_b = ""
      
      @source_content = nil
      @target_content = nil
    end
    
    # isAlphanum -- return true if the character is a letter, digit, underscore,
    # dollar sign, or non-ASCII character
    def isAlphanum(c)
      return false if !c || c == EOF
      return ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') ||
              (c >= 'A' && c <= 'Z') || c == '_' || c == '$' ||
              c == '\\' || c[0].ord > 126)
    end
    
    # get -- return the next character from stdin. Watch out for lookahead. If
    # the character is a control character, translate it to a space or linefeed.
    def get()
      c = @source_content.getc
      return EOF if(!c)
      c = c.chr
      return c if (c >= " " || c == "\n" || c.unpack("c") == EOF)
      return "\n" if (c == "\r")
      return " "
    end
    
    # Get the next character without getting it.
    def peek()
      lookaheadChar = @source_content.getc
      @source_content.ungetc(lookaheadChar)
      return lookaheadChar.chr
    end
    
    # mynext -- get the next character, excluding comments.
    # peek() is used to see if a '/' is followed by a '/' or '*'.
    def mynext()
      c = get
      if (c == "/")
        if(peek == "/")
          while(true)
            c = get
            if (c <= "\n")
              return c
            end
          end
        end
        if(peek == "*")
          get
          while(true)
            case get
            when "*"
              if (peek == "/")
                get
                return " "
              end
            when EOF
              raise "Unterminated comment"
            end
          end
        end
      end
      return c
    end
    
    
    # action -- do something! What you do is determined by the argument: 1
    # Output A. Copy B to A. Get the next B. 2 Copy B to A. Get the next B.
    # (Delete A). 3 Get the next B. (Delete B). action treats a string as a
    # single character. Wow! action recognizes a regular expression if it is
    # preceded by ( or , or =.
    def action(a)
      if(a==1)
        @target_content.write @the_a
      end
      if(a==1 || a==2)
        @the_a = @the_b
        if (@the_a == "\'" || @the_a == "\"")
          while (true)
            @target_content.write @the_a
            @the_a = get
            break if (@the_a == @the_b)
            raise "Unterminated string literal" if (@the_a <= "\n")
            if (@the_a == "\\")
              @target_content.write @the_a
              @the_a = get
            end
          end
        end
      end
      if(a==1 || a==2 || a==3)
        @the_b = mynext
        if (@the_b == "/" && (@the_a == "(" || @the_a == "," || @the_a == "=" ||
                              @the_a == ":" || @the_a == "[" || @the_a == "!" ||
                              @the_a == "&" || @the_a == "|" || @the_a == "?" ||
                              @the_a == "{" || @the_a == "}" || @the_a == ";" ||
                              @the_a == "\n"))
          @target_content.write @the_a
          @target_content.write @the_b
          while (true)
            @the_a = get
            if (@the_a == "/")
              break
            elsif (@the_a == "\\")
              @target_content.write @the_a
              @the_a = get
            elsif (@the_a <= "\n")
              raise "Unterminated RegExp Literal"
            end
            @target_content.write @the_a
          end
          @the_b = mynext
        end
      end
    end
    
    def minify(source_content)
      @source_content = StringIO.new(source_content)
      @target_content = StringIO.new

      @the_a = "\n"

      action(3)
      while (@the_a != EOF)
        case @the_a
        when " "
          if (isAlphanum(@the_b))
            action(1)
          else
            action(2)
          end
        when "\n"
          case (@the_b)
          when "{","[","(","+","-"
            action(1)
          when " "
            action(3)
          else
            if (isAlphanum(@the_b))
              action(1)
            else
              action(2)
            end
          end
        else
          case (@the_b)
          when " "
            if (isAlphanum(@the_a))
              action(1)
            else
              action(3)
            end
          when "\n"
            case (@the_a)
            when "}","]",")","+","-","\"","\\", "'", '"'
              action(1)
            else
              if (isAlphanum(@the_a))
                action(1)
              else
                action(3)
              end
            end
          else
            action(1)
          end
        end
      end
      
      @target_content.rewind
      @target_content.read
    end
  end
end
