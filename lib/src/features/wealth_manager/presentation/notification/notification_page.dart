import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/custom_appbar.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PhoneAppBar(title: "Notification"),
      body: FutureBuilder(
        future: NotificationApi.wNotificationList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var response = snapshot.data;
            if (response!.isSuccess &&
                response.r != null &&
                response.r!.isNotEmpty) {
              return ListView.separated(
                itemCount: response.r!.length,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  var model = response.r![index];
                  bool isExpanded = false;
                  return PhoneNotificationItem(
                    title: model.title,
                    message: model.body,
                    createdAt: model.createdAt,
                    isExpanded: isExpanded,
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
              );
            } else if (response.isSuccess &&
                (response.r == null || response.r!.isEmpty)) {
              return const NoDataView(
                title: 'No notifications',
                subtitle: 'You are all caught up.',
                isRefreshButton: false,
              );
            } else {
              return Center(child: Text('Error: ${response.m}'));
            }
          } else {
            return const Center(child: Text('Unknown error occurred'));
          }
        },
      ),
    );
  }
}

class NotificationDrawer extends StatelessWidget {
  const NotificationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      width: 597,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const TitleText("Notification"),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder(
                future: NotificationApi.wNotificationList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    var response = snapshot.data;
                    if (response!.isSuccess &&
                        response.r != null &&
                        response.r!.isNotEmpty) {
                      return ListView.separated(
                        itemCount: response.r!.length,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          var model = response.r![index];
                          return NotificationItem(
                            title: model.title,
                            message: model.body,
                            createdAt: model.createdAt,
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                      );
                    } else if (response.isSuccess &&
                        (response.r == null || response.r!.isEmpty)) {
                      return const NoDataView(
                title: 'No notifications',
                subtitle: 'You are all caught up.',
                isRefreshButton: false,
              );
                    } else {
                      return Center(child: Text('Error: ${response.m}'));
                    }
                  } else {
                    return const Center(child: Text('Unknown error occurred'));
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final DateTime createdAt;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
      width: Get.width,
      radius: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(color: context.theme.disabledColor),
                ),
                const SizedBox(height: 4),
                Text(
                  createdAt.timeAgo,
                  style: TextStyle(
                      color: context.theme.disabledColor.withValues(alpha: 0.5),
                      fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            createdAt.dateWithMonthYear,
            style: TextStyle(
                color: context.theme.disabledColor.withValues(alpha: 0.5),
                fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class PhoneNotificationItem extends StatefulWidget {
  final String title;
  final String message;
  final bool isExpanded;
  final DateTime createdAt;

  const PhoneNotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isExpanded,
  });

  @override
  State<PhoneNotificationItem> createState() => _PhoneNotificationItemState();
}

class _PhoneNotificationItemState extends State<PhoneNotificationItem> {
  bool isExpanded = false;

  @override
  void initState() {
    isExpanded = widget.isExpanded;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isLongText = widget.message.length > 100;

    return FadeInUp(
      child: CustomCardWidget(
        radius: 16,
        padding: const EdgeInsets.fromLTRB(12, 11, 22, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.message,
                    maxLines: isExpanded ? null : 4,
                    overflow: isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.theme.disabledColor.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  if (isLongText)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          isExpanded ? 'Read less' : 'Read more',
                          style: TextStyle(
                            color: context.theme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 11),
                  Text(
                    widget.createdAt.timeAgo,
                    style: TextStyle(
                      color: context.theme.disabledColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.createdAt.dateWithMonthYear,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: context.theme.disabledColor,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
