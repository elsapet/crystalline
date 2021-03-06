
require "./mutable"

class DirectedAdjacencyGraph(T, EdgeList) < MutableGraph(T, DirectedEdge, EdgeList)

  def directed?; true; end

  def remove_edge(u, v)
    @vertice_dict[u].delete(v) if @vertice_dict[u]
  end

  protected def basic_add_edge(u, v)
    @vertice_dict[u].add(v)
  end

end

class AdjacencyGraph(T, EdgeList) < MutableGraph(T, UndirectedEdge, EdgeList)

  def directed?; false; end

  def remove_edge(u, v)
    @vertice_dict[u].delete(v) if @vertice_dict[u]
    @vertice_dict[v].delete(u) if @vertice_dict[v]
  end

  protected def basic_add_edge(u, v)
    @vertice_dict[u].add(v)
    @vertice_dict[v].add(u)
  end

end

abstract class Graph(T, Edge)

  def to_adjacency
    result = directed? ? DirectedAdjacencyGraph(T, Set).new : AdjacencyGraph(T, Set).new
    each_vertex { |v| result.add_vertex(v) }
    each_edge { |u,v| result.add_edge(u, v) }
    result
  end

  def reverse
    return self unless directed?
    result = DirectedAdjacencyGraph(T, Set).new
    each_vertex { |v| result.add_vertex v }
    each_edge { |u,v| result.add_edge(v, u) }
    result
  end

end
