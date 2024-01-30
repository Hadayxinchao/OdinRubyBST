require_relative 'node.rb'

class Tree
  attr_accessor :root, :values

  def initialize
    @values = create_array
    @root = build_tree(@values)
  end

  def create_array
    Array.new(15) {rand(1..100)}
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.value}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  def insert(value, node = @root)
    return Node.new(value) if node.nil?
    if node.value == value
      return node
    elsif node.value > value
      node.left = insert(value, node.left)
    else
      node.right = insert(value, node.right)
    end
    @root = node
  end

  def delete(value, node = @root)
    return nil if node.nil?
    if node.value > value
      node.left = delete(value, node.left)
      return node
    elsif node.value < value
      node.right = delete(value, node.right)
      return node
    end

    if node.left.nil?
      return node.right
    elsif node.right.nil?
      return node.left
    else
      succParrent = node
      succ = node.right
      until succ.left.nil?
        succParrent = succ
        succ = succ.left
      end

      if succParrent != node
        succParrent.left = succ.right
      else
        succParrent.right = succ.right
      end

      node.value = succ.value
      return node
    end
  end
  
  def find(value, temp_root = @root)
    return temp_root if temp_root.nil?
    if temp_root.value > value
      temp_root = find(value, temp_root.left)
    elsif temp_root.value < value
      temp_root = find(value, temp_root.right)
    else
      return temp_root
    end
  end

  def level_order
    return [] if @root.nil?

    queue = Queue.new
    queue << @root

    if block_given?
      while !queue.empty?
        node = queue.pop
        yield node
        queue << node.left if node.left
        queue << node.right if node.right
      end
    else
      result = []
      while !queue.empty?
        node = queue.pop
        result << node.value
        queue << node.left if node.left
        queue << node.right if node.right
      end
      result
    end
  end

  def inorder(node = @root, &block)
    return [] if node.nil?

    if block_given?
      inorder(node.left, &block)
      yield node 
      inorder(node.right, &block)
    else
      result = []
      inorder(node.left) { |n| result << n.value } 
      result << node.value
      inorder(node.right) { |n| result << n.value }
      result
    end
  end

  def preorder(node = @root, &block)
    return [] if node.nil?

    if block_given?
      yield node
      preorder(node.left, &block)
      preorder(node.right, &block)
    else
      result = []
      result << node.value
      preorder(node.left) { |n| result << n.value}
      preorder(node.right) { |n| result << n.value}
      result
    end
  end

  def postorder(node = @root, &block)
    return [] if node.nil?

    if block_given?
      preorder(node.left, &block)
      preorder(node.right, &block)
      yield node
    else
      result = []
      preorder(node.left) { |n| result << n.value }
      preorder(node.right) { |n| result << n.value }
      result << node.value
      result
    end
  end

  def height(value, temp_root = find(value))
    return -1 if temp_root.nil?
    left_h = height(value, temp_root.left)
    right_h = height(value, temp_root.right)
    if left_h > right_h
      return left_h + 1
    else
      return right_h + 1
    end
  end
  
  def depth(value, temp_root = @root)
    return -1 if temp_root.nil?
    distance = -1
    return distance + 1 if temp_root.value == value
    distance = depth(value, temp_root.left)
    return distance + 1 if distance >= 0
    distance = depth(value, temp_root.right)
    return distance + 1 if distance >= 0
    return distance
  end

  def balanced?
    left_height = self.height(@root.left.value)
    right_height = self.height(@root.right.value)
    if left_height < right_height
      return right_height - left_height <= 1
    else
      return left_height - right_height <= 1
    end
  end

  def rebalance
    @root = build_tree(self.level_order)
  end

  private
  def build_tree(arr)
    return nil if arr.empty?
    arr = arr.sort.uniq
    mid = arr.length / 2 
    node = Node.new(arr[mid])
    node.left = build_tree(arr[0...mid])
    node.right = build_tree(arr[mid+1..])
    return node
  end
end

