import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/contact.dart';
import '../providers/app_state.dart';

import 'contact_card.dart';

final class ContactsListPage extends StatefulWidget {
  const ContactsListPage({super.key});

  @override
  State<ContactsListPage> createState() => _ContactsListPageState();
}

class _ContactsListPageState extends State<ContactsListPage> {
  Iterable<Contact> _contacts = [];
  var _searchText = '';
  final _searchTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final appState = context.read<AppState>();

    if (mounted) {
      Future.microtask(() => appState.loadState());
    }
  }

  void _filterContacts(String searchText) {
    final appState = context.read<AppState>();

    setState(() => _searchText = searchText);

    _contacts = appState.contacts.where((c) =>
        c.taxCode.toLowerCase().contains(searchText.toLowerCase()) ||
        c.firstName.toLowerCase().contains(searchText.toLowerCase()) ||
        c.lastName.toLowerCase().contains(searchText.toLowerCase()) ||
        c.birthPlace.name.toLowerCase().contains(searchText.toLowerCase()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState value, Widget? child) {
        void onReorder(int oldIndex, int newIndex) {
          final contacts = value.contacts;

          if (newIndex > oldIndex) {
            newIndex -= 1;
          }

          final movedContact = contacts.removeAt(oldIndex);
          contacts.insert(newIndex, movedContact);
          value.updateContacts(contacts);
          value.saveState();
        }

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: 400,
                  child: TextField(
                    autocorrect: false,
                    controller: _searchTextEditingController,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Cerca...',
                        suffix: IconButton(
                            onPressed: () => setState(
                                () => _searchTextEditingController.text = ''),
                            icon: const Icon(Icons.clear))),
                  ),
                ),
                AnimatedReorderableGridView(
                  items: value.contacts,
                  scrollDirection: Axis.vertical,
                  sliverGridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                          crossAxisSpacing: 50,
                          mainAxisExtent: 280,
                          maxCrossAxisExtent: 800),
                  longPressDraggable: false,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final contact = value.contacts[index];
                    return AnimatedContainer(
                      key: ValueKey(contact.id),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Center(child: ContactCard(contact: contact)),
                    );
                  },
                  enterTransition: [FadeIn(), ScaleIn()],
                  exitTransition: [SlideInLeft()],
                  insertDuration: const Duration(milliseconds: 400),
                  removeDuration: const Duration(milliseconds: 400),
                  onReorder: onReorder,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
