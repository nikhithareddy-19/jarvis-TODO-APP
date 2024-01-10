enum TodoPriority {
  Low,
  Medium,
  High,
}

enum Status {
  ToDo,
  InProgress,
  Done,
}

enum Category {
  Work,
  Personal,
  Shopping,
  Others,
}

class TodoModel {
  int? id;
  String? title;
  TodoPriority? priority;
  DateTime? dueDate;
  String? description;
  Status? status;
  Category? category;

  TodoModel({
    this.id,
    this.title,
    this.priority,
    this.dueDate,
    this.description,
    this.status,
    this.category,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      priority: TodoPriority.values
          .firstWhere((e) => e.toString().split('.').last == json['priority']),
      dueDate: DateTime.parse(json['due_date']),
      description: json['description'],
      status: Status.values
          .firstWhere((e) => e.toString().split('.').last == json['status']),
      category: Category.values
          .firstWhere((e) => e.toString().split('.').last == json['Category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.toString().split('.').last,
      'due_date': dueDate.toString(),
      'description': description,
      'status': status.toString().split('.').last,
      'Category': category.toString().split('.').last,
    };
  }
}
