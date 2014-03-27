#!/usr/bin/ruby
require 'slim'

class RegularPolygon
    def initialize n
        raise "n must be greater than 2" if n < 3
        @n = n
        @name,@nick = "#{@n}th Polygon", "polygon_#{@n}"
        @c = [50,50]
        @r = 49
        @alpha = 2*Math::PI/@n
        @points = @n.times.to_a.map {|x| [Math::cos(x*@alpha)*@r+@c[0], Math::sin(x*@alpha)*@r+@c[1]] }
        self.align
        end
    def align
        n = @n - 2
        @l = Math::sqrt( (@points[n][0]-@points[n+1][0])**2 +  (@points[n][1] - @points[n+1][1])**2 ) 
        puts (@points[0][0] - @points[1][0])/@l
        @dlt = Math::acos((@points[0][0] - @points[1][0])/@l)
        @points = @n.times.to_a.map {|x| [Math::cos(-x*@alpha+@dlt)*@r+@c[0], Math::sin(-x*@alpha+@dlt)*@r+@c[1]] }
        end        

    def lines
        @n.times.to_a.map {|i| i+1<@n?[@points[i], @points[i+1]]:[@points[-1], @points[0]]}
        end

    def to_xml *args
        lines = self.lines
        if args.include?"fractal"
            type,g="fractal","#{@nick}_rec"
        else
            type,g="shape","main"
        end
        Slim::Template.new('polynom.slim', {:pretty=>true}).render \
            Object.new, :name=> @name, :lines=>lines, :type=>type, :nick=>@nick, :g=>g
        end

    def write_svgs
        File.open("shape_#{@nick}.svg", 'w') { |f|
            f.write self.to_xml.to_s
        }
        File.open("fractal_#{@nick}.svg", 'w') { |f|
            f.write self.to_xml("fractal").to_s 
        }
        end
            
    def p_points
        puts @points.to_s
        end
    def to_s
        @name
        end
end

class Star < RegularPolygon
    def initialize n,step
        super n
        points,@step = @points,step
        @name,@nick = "{#{@n},#{@step}} Star", "star_#{@n}_#{@step}"
        i,n = 0,@n
        puts i,n,@step
        @points = @n.times.to_a.map {points[i=(i+@step)%n]}
        self.align
        @points = @n.times.to_a.map {points[i=(i+@step)%n]}
    end
end
class SuperStar < RegularPolygon
    def initialize n
        super n
        @name,@nick = "{#{@n} SuperStar", "superstar_#{@n}"
    end
    def lines
        #@points.combination(2).to_a
        @points.permutation(2).to_a
    end
end


if __FILE__ == $0
    if not (1..2) === ARGV.length
        puts 'Usage: '
        puts "       #{$0} N   # generate a Nth regular polygom"
        puts "       #{$0} N S # generate a {N,S} star polygom"
        puts "       #{$0} + N # generate a N SuperStar"
        exit
    elsif ARGV.length == 1
        pol = RegularPolygon.new ARGV[0].to_i
    elsif ARGV[0] == '+'
        pol = SuperStar.new ARGV[1].to_i
    else
        pol = Star.new ARGV[0].to_i, ARGV[1].to_i
    end
    puts pol.to_xml.to_s
    pol.write_svgs
end
