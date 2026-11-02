class GitHubActivityModel {
  final int id;
  final int projectId;
  final String activityType; // 'commit', 'pull_request', 'issue'
  final String title;
  final String? description;
  final String? commitHash;
  final int? prNumber;
  final String? branch;
  final String authorUsername;
  final String? url;
  final String timestamp;

  const GitHubActivityModel({
    required this.id,
    required this.projectId,
    required this.activityType,
    required this.title,
    this.description,
    this.commitHash,
    this.prNumber,
    this.branch,
    required this.authorUsername,
    this.url,
    required this.timestamp,
  });

  factory GitHubActivityModel.fromJson(Map<String, dynamic> json) {
    return GitHubActivityModel(
      id: json['id'] as int? ?? 0,
      projectId: json['project_id'] as int? ?? 0,
      activityType: json['activity_type'] as String? ?? 'commit',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      commitHash: json['commit_hash'] as String?,
      prNumber: json['pr_number'] as int?,
      branch: json['branch'] as String?,
      authorUsername: json['author_username'] as String? ?? 'contributor',
      url: json['url'] as String?,
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'activity_type': activityType,
      'title': title,
      'description': description,
      'commit_hash': commitHash,
      'pr_number': prNumber,
      'branch': branch,
      'author_username': authorUsername,
      'url': url,
      'timestamp': timestamp,
    };
  }
}
