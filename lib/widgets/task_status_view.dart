import 'package:flutter/material.dart';
import 'package:task_manager/data/model/api_response.dart';
import 'package:task_manager/data/model/task_model.dart';
import 'package:task_manager/data/model/task_status_count_model.dart';
import 'package:task_manager/data/service/api_caller.dart';
import 'package:task_manager/utils/app_colors.dart';
import 'package:task_manager/utils/urls.dart';
import 'package:task_manager/widgets/task_card.dart';
import 'package:task_manager/widgets/task_count_by_status.dart';

// all 4 status screens (new / progress / completed / cancel) look exactly
// the same, only the status word is different. so instead of writing the
// same widget tree 4 times, made this one and just pass the status in
class TaskStatusView extends StatefulWidget {
  final String status;

  const TaskStatusView({super.key, required this.status});

  @override
  State<TaskStatusView> createState() => _TaskStatusViewState();
}

class _TaskStatusViewState extends State<TaskStatusView> {
  bool _isLoading = false;
  List<TaskModel> _taskList = [];
  List<TaskStatusCountModel> _countList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // getting the task list and the count numbers together
    final results = await Future.wait([
      ApiCaller.getRequest(url: Urls.getTaskByStatusURL(widget.status)),
      ApiCaller.getRequest(url: Urls.getTaskCountURL),
    ]);

    final ApiResponse taskResponse = results[0];
    final ApiResponse countResponse = results[1];

    if (taskResponse.isSuccess) {
      final List<dynamic> data = taskResponse.responseData['data'] ?? [];
      _taskList = data
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(taskResponse.errorMessage.toString())),
      );
    }

    if (countResponse.isSuccess) {
      final List<dynamic> data = countResponse.responseData['data'] ?? [];
      _countList = data
          .map((e) => TaskStatusCountModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // finds the count for a status, returns 0 if that status is not in the list yet
  int _countFor(String status) {
    final match = _countList.where((element) => element.sId == status);
    if (match.isEmpty) return 0;
    return match.first.sum ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  TaskCountByStatus(title: 'New', count: _countFor('New')),
                  const SizedBox(width: 8),
                  TaskCountByStatus(
                    title: 'Progress',
                    count: _countFor('Progress'),
                  ),
                  const SizedBox(width: 8),
                  TaskCountByStatus(
                    title: 'Completed',
                    count: _countFor('Completed'),
                  ),
                  const SizedBox(width: 8),
                  TaskCountByStatus(
                    title: 'Cancelled',
                    count: _countFor('Cancelled'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _taskList.isEmpty
                // wrapping the empty text in a ListView too so pull to
                // refresh still works even when there is nothing to show
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('No task found here')),
                    ],
                  )
                : ListView.builder(
                    itemCount: _taskList.length,
                    itemBuilder: (context, index) {
                      final task = _taskList[index];
                      return TaskCard(
                        taskModel: task,
                        CardColor: AppColors.statusColor(task.status ?? ''),
                        refreshParent: _loadData,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
