
require "../containers/common"

class NoVertexError < Exception; end

class Edge(T)
  include Comparable(Edge)

  property :source, :target

  def eql?(edge)
    @source == edge.source && @target == edge.target
  end
  alias_method :==, :eql?

  def reverse
    self.class.new(@target, @source)
  end

  def [](index); index == 0 ? @source : @target; end

  def to_s
    "(#{@source}-#{@target})"
  end

  def to_a; [@source, @target]; end

  def <=>(e); self.to_a <=> e.to_a; end
end

class DirectedEdge(T) < Edge(T)
  def initialize(@source : T, @target : T); end
end

class UndirectedEdge(T) < Edge(T)

  def initialize(@source : T, @target : T); end

  def eql?(edge)
    super || (@target == edge.source && @source == edge.target)
  end

  def hash
    @source.hash ^ @target.hash
  end

  def to_s; "(#{@source}=#{@target})"; end
end

abstract class Graph(T, Edge)
  include Enumerable(T)
  
  abstract def each_vertex(&block : T ->)
  abstract def each_adjacent(v, &block : T ->)

  def each_edge
    if directed?
      each_vertex do |u|
        each_adjacent(u) { |v| yield(u, v) }
      end
    else
      each_edge_aux { |u, v| yield(u, v) } # concrete graphs should to this better
    end
  end

  def each
    each_vertex { |i| yield i }
  end

  def directed?; false; end

  alias_method :has_vertex?, :include?  

  def empty?; num_vertices == 0; end

  alias_method :vertices, :to_a

  def edges
    result = [] of Edge(T)
    each_edge { |u, v| result << Edge(T).new(u, v) }
    result
  end

  def adjacent_vertices(v)
    r = [] of T
    each_adjacent(v) { |u| r << u }
    r
  end

  def out_degree(v)
    r = 0
    each_adjacent(v) { |u| r += 1 }
    r
  end

  def size()
    inject(0) { |n, v| n + 1 }
  end
  alias_method :num_vertices, :size

  def num_edges
    r = 0
    each_edge { |u, v| r += 1 }
    r
  end

  delegate to_s, edges.sort

  def eql?(g)
    same?(g) || 
      g.is_a?(Graph) && directed? == g.directed? && 
      g.inject(0) { |n, v| has_vertex?(v) || return false; n + 1 } == num_vertices && 
      g.each_edge { |u, v| has_edge?(u, v) || return false } && 
      num_edges == g.num_edges
  end
  alias_method :==, :eql?

  private def each_edge_aux
    visited = {} of UndirectedEdge(T) => Bool
    each_vertex do |u|
      each_adjacent(u) do |v|
        edge = UndirectedEdge(T).new(u, v)
        unless visited.has_key? edge
          visited[edge] = true
          yield(u, v)
        end
      end
    end
  end

end
