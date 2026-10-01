import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import 'chat_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({
    super.key,
  });

  @override
  State<UsersScreen> createState() =>
      _UsersScreenState();
}

class _UsersScreenState
    extends State<UsersScreen> {
  final ChatService _chatService =
      ChatService();

  final TextEditingController
      _searchController =
      TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      () {
        setState(() {
          _searchQuery =
              _searchController.text
                  .trim()
                  .toLowerCase();
        });
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getDisplayName(
    Map<String, dynamic> user,
  ) {
    final username =
        user['username']
                ?.toString()
                .trim() ??
            '';

    final firstName =
        user['firstName']
                ?.toString()
                .trim() ??
            '';

    final lastName =
        user['lastName']
                ?.toString()
                .trim() ??
            '';

    final fullName =
        '$firstName $lastName'.trim();

    if (username.isNotEmpty) {
      return username;
    }

    if (fullName.isNotEmpty) {
      return fullName;
    }

    return 'Firebase User';
  }

  String _getSearchableText(
    Map<String, dynamic> user,
  ) {
    final username =
        user['username']
                ?.toString()
                .toLowerCase() ??
            '';

    final firstName =
        user['firstName']
                ?.toString()
                .toLowerCase() ??
            '';

    final lastName =
        user['lastName']
                ?.toString()
                .toLowerCase() ??
            '';

    final email =
        user['email']
                ?.toString()
                .toLowerCase() ??
            '';

    return '$username $firstName $lastName $email';
  }

  String _getInitial(
    String displayName,
  ) {
    if (displayName.isEmpty) {
      return '?';
    }

    return displayName[0]
        .toUpperCase();
  }

  Widget _buildAvatar(
    Map<String, dynamic> user,
    String displayName,
  ) {
    final image =
        user['image']
                ?.toString()
                .trim() ??
            '';

    if (image.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage:
            NetworkImage(image),
        onBackgroundImageError:
            (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 28,
      child: Text(
        _getInitial(displayName),
        style: const TextStyle(
          fontSize: 21,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        10,
      ),
      child: TextField(
        controller:
            _searchController,
        textInputAction:
            TextInputAction.search,
        decoration:
            InputDecoration(
          hintText:
              'Search by name or email...',
          prefixIcon:
              const Icon(
            Icons.search,
          ),
          suffixIcon:
              _searchController
                      .text
                      .isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController
                            .clear();
                      },
                      icon:
                          const Icon(
                        Icons.clear,
                      ),
                    )
                  : null,
          filled: true,
          fillColor: Theme.of(
            context,
          )
              .colorScheme
              .surfaceContainerHighest
              .withValues(
                alpha: 0.55,
              ),
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            borderSide:
                BorderSide.none,
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            borderSide:
                BorderSide.none,
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            borderSide:
                BorderSide(
              color: Theme.of(
                context,
              )
                  .colorScheme
                  .primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(
    BuildContext context,
    QueryDocumentSnapshot<
        Map<String, dynamic>> document,
  ) {
    final user =
        document.data();

    final displayName =
        _getDisplayName(user);

    final email =
        user['email']
                ?.toString()
                .trim() ??
            '';

    final userId =
        user['uid']
                ?.toString()
                .trim() ??
            document.id;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(
                  otherUserId: userId,
                  otherUserName:
                      displayName,
                ),
              ),
            );
          },
          child: Padding(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            child: Row(
              children: [
                _buildAvatar(
                  user,
                  displayName,
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        email.isNotEmpty
                            ? email
                            : 'No email available',
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            TextStyle(
                          fontSize: 13,
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Container(
                  padding:
                      const EdgeInsets
                          .all(8),
                  decoration:
                      BoxDecoration(
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary
                        .withValues(
                          alpha: 0.10,
                        ),
                    shape:
                        BoxShape.circle,
                  ),
                  child:
                      Icon(
                    Icons
                        .chat_bubble_outline,
                    size: 20,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(
            context,
          ),
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<
                    Map<String,
                        dynamic>>>(
              stream:
                  _chatService
                      .getOtherUsers(),
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(24),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          Icon(
                            Icons
                                .error_outline,
                            size: 48,
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .error,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          const Text(
                            'Unable to load users.',
                            textAlign:
                                TextAlign
                                    .center,
                            style:
                                TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            '${snapshot.error}',
                            textAlign:
                                TextAlign
                                    .center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allUsers =
                    snapshot.data
                            ?.docs ??
                        [];

                final filteredUsers =
                    allUsers
                        .where(
                          (document) {
                            final user =
                                document
                                    .data();

                            final searchableText =
                                _getSearchableText(
                              user,
                            );

                            return searchableText
                                .contains(
                              _searchQuery,
                            );
                          },
                        )
                        .toList();

                if (allUsers.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding:
                          EdgeInsets.all(
                        24,
                      ),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          Icon(
                            Icons
                                .people_outline,
                            size: 56,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            'No other users are available yet.',
                            textAlign:
                                TextAlign
                                    .center,
                            style:
                                TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            'Other Firebase users will appear here.',
                            textAlign:
                                TextAlign
                                    .center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (filteredUsers
                    .isEmpty) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(24),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize
                                .min,
                        children: [
                          const Icon(
                            Icons
                                .search_off,
                            size: 56,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          const Text(
                            'No users found',
                            style:
                                TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            'No users match "$_searchQuery".',
                            textAlign:
                                TextAlign
                                    .center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets
                          .only(
                    bottom: 16,
                  ),
                  itemCount:
                      filteredUsers
                          .length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    return _buildUserTile(
                      context,
                      filteredUsers[
                          index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}