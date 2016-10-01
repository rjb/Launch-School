# This class represents a todo item and its associated data
class Todo
  DONE_MARKER = 'X'
  UNDONE_MARKER = ' '

  attr_accessor :title, :description, :done

  def initialize(title, description='')
    @title = title
    @description = description
    @done = false
  end

  def done!
    self.done = true
  end

  def done?
    done
  end

  def undone!
    self.done = false
  end

  def to_s
    "[#{done? ? DONE_MARKER : UNDONE_MARKER}] #{title}"
  end
end

# This class represents a collection of Todo objects
class TodoList
  attr_accessor :title

  def initialize(title)
    @title = title
    @todos = []
  end

  def add(todo)
    raise TypeError, 'can only add Todo objects' unless todo.instance_of?(Todo)
    @todos << todo
  end

  alias_method :<<, :add

  def each
    i = 0
    while i < @todos.length
      yield(@todos[i])
      i += 1
    end
    self
  end

  def select
    list = TodoList.new(title)
    each do |todo|
      list.add(todo) if yield(todo)
    end
    list
  end

  def size
    @todos.size
  end

  def first
    @todos.first
  end

  def last
    @todos.last
  end

  def item_at(idx)
    @todos.fetch(idx)
  end

  def done!
    @todos.each_index do |idx|
      mark_done_at(idx)
    end
  end

  def mark_done_at(idx)
    item_at(idx).done!
  end

  def mark_undone_at(idx)
    item_at(idx).undone!
  end

  def shift
    @todos.shift
  end

  def pop
    @todos.pop
  end

  def remove_at(idx)
    @todos.delete(item_at(idx))
  end

  def to_s
    string = "----#{title}----\n"
    string << @todos.map(&:to_s).join("\n")
    string
  end
end

todo1 = Todo.new("Buy milk")
todo2 = Todo.new("Clean room")
todo3 = Todo.new("Go to gym")

list = TodoList.new("Today's Todos")
list.add(todo1)
list.add(todo2)
list.add(todo3)

puts list

list.pop

puts list

list.mark_done_at(1)

puts list

todo1 = Todo.new("Walk the dog")
todo2 = Todo.new("Write a blog post")
todo3 = Todo.new("Call Joe")

list = TodoList.new("Tomorrow's Todos")
list.add(todo1)
list.add(todo2)
list.add(todo3)

puts "----#{list.title}----"
list.each { |todo| puts todo }

todo1 = Todo.new("Make dinner reservations")
todo2 = Todo.new("Order new hard drive")
todo3 = Todo.new("Email Elizabeth")

list = TodoList.new("Friday's Todos")
list.add(todo1)
list.add(todo2)
list.add(todo3)

todo1.done!

results = list.select { |todo| todo.done? }    # you need to implement this method

puts results.inspect
