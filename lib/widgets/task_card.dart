import 'package:flutter/material.dart';
import '../data/model/api_response.dart';
import '../data/model/task_model.dart';
import '../data/service/api_caller.dart';
import '../utils/urls.dart';

class TaskCard extends StatefulWidget {
  final TaskModel taskModel;
  final Color CardColor;
  final VoidCallback refreshParent;

  const TaskCard({
    super.key,
    required this.taskModel,
    required this.CardColor,
    required this.refreshParent,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final TextEditingController editTitleController = TextEditingController();
  final TextEditingController editDescriptionController =
      TextEditingController();

  static const List<String> statusOptions = [
    'New',
    'Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  void dispose() {
    editTitleController.dispose();
    editDescriptionController.dispose();
    super.dispose();
  }

  // ---------- Status change (still used standalone if you tap the chip) ----------

  Future<void> changeStatus(String status, {bool popTwice = false}) async {
    final ApiResponse response = await ApiCaller.getRequest(
      url: Urls.updateTaskStatusURL(widget.taskModel.sId.toString(), status),
    );

    if (response.isSuccess) {
      widget.refreshParent();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task updated successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.responseData['data'].toString())),
      );
    }

    Navigator.pop(context); // close status dialog
    if (popTwice) Navigator.pop(context); // also close edit dialog
  }

  void ShowChnageDialog({bool fromEditDialog = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statusOptions.map((status) {
            return Card(
              color: widget.taskModel.status == status ? Colors.green : null,
              child: ListTile(
                title: Text(status),
                onTap: () => changeStatus(status, popTwice: fromEditDialog),
                trailing: widget.taskModel.status == status
                    ? Icon(Icons.check_circle, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------- Edit task (title / description / status, all together) ----------

  Future<void> updateTask(String selectedStatus) async {
    final ApiResponse response = await ApiCaller.PostRequest(
      url: Urls.updateTaskURL(widget.taskModel.sId.toString()),
      body: {
        "title": editTitleController.text.trim(),
        "description": editDescriptionController.text.trim(),
        "status": selectedStatus,
      },
    );

    if (response.isSuccess) {
      Navigator.pop(context); // close the edit dialog
      widget.refreshParent();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task updated successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.responseData['data'].toString())),
      );
    }
  }

  void showEditTaskDialog() {
    editTitleController.text = widget.taskModel.title ?? '';
    editDescriptionController.text = widget.taskModel.description ?? '';
    String selectedStatus = widget.taskModel.status ?? 'New';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Edit Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: editTitleController,
                  decoration: InputDecoration(hintText: 'Title'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: editDescriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(hintText: 'Description'),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: InputDecoration(labelText: 'Status'),
                  items: statusOptions.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedStatus = value);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (editTitleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Title cannot be empty')),
                    );
                    return;
                  }
                  updateTask(selectedStatus);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- Delete task ----------

  Future<void> deleteTask() async {
    final ApiResponse response = await ApiCaller.getRequest(
      url: Urls.deleteTaskURL(widget.taskModel.sId.toString()),
    );

    if (response.isSuccess) {
      widget.refreshParent();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task deleted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.responseData['data'].toString())),
      );
    }
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteTask();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.taskModel.title.toString(),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.taskModel.description.toString()),
          Text('Date:${widget.taskModel.createdDate}'),
          Row(
            children: [
              Chip(
                label: Text(widget.taskModel.status.toString()),
                backgroundColor: widget.CardColor,
                labelStyle: TextStyle(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),

              Spacer(),

              // Pencil icon now opens the full edit dialog (title + description + status)
              IconButton(
                onPressed: () {
                  showEditTaskDialog();
                },
                icon: Icon(Icons.edit_note, color: Colors.orange),
              ),
              IconButton(
                onPressed: () {
                  confirmDelete();
                },
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
