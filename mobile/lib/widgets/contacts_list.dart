import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';

import 'contact_card.dart';

final class ContactsList extends StatefulWidget {
  const ContactsList({super.key});

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  List<Contact> _contacts = [];
  var _searchText = '';

  final _searchTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AppState>().loadContacts();
  }

  void _filterContacts(String searchText) {
    final appState = context.read<AppState>();

    setState(() => _searchText = searchText);

    appState.setSearchState(_searchText.isNotEmpty);

    _contacts = appState.contacts
        .where((c) =>
            c.taxCode.toLowerCase().contains(searchText.toLowerCase()) ||
            c.firstName.toLowerCase().contains(searchText.toLowerCase()) ||
            c.lastName.toLowerCase().contains(searchText.toLowerCase()) ||
            c.birthPlace.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState value, Widget? child) {
        void onReorder(int oldIndex, int newIndex) {
          HapticFeedback.lightImpact();
          final contacts = value.contacts;

          final contact = contacts.removeAt(oldIndex);
          contacts.insert(newIndex, contact);

          if (oldIndex < newIndex) {
            for (int i = oldIndex; i <= newIndex; i++) {
              contacts[i].listIndex = i;
            }
          } else {
            for (int i = newIndex; i <= oldIndex; i++) {
              contacts[i].listIndex = i;
            }
          }

          value.updateContacts(contacts);
          value.saveContacts();
        }

        return Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: 400,
                  child: TextField(
                    autocorrect: false,
                    controller: _searchTextEditingController,
                    onChanged: (searchText) => _filterContacts(searchText),
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: AppLocalizations.of(context)!.search,
                        suffix: IconButton(
                            onPressed: () => setState(() {
                                  _searchTextEditingController.text = '';
                                  _filterContacts('');
                                  FocusScope.of(context).unfocus();
                                }),
                            icon: const Icon(Icons.clear))),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: _searchText.isEmpty
                        ? AnimatedReorderableGridView(
                            items: value.contacts,
                            sliverGridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    crossAxisSpacing: 50,
                                    mainAxisExtent: 280,
                                    maxCrossAxisExtent: 800),
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final contact = value.contacts[index];
                              return AnimatedContainer(
                                key: ValueKey(contact.id),
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: Center(
                                    child: ContactCard(contact: contact)),
                              );
                            },
                            enterTransition: [FadeIn(), ScaleIn()],
                            exitTransition: [SlideInLeft()],
                            insertDuration: const Duration(milliseconds: 400),
                            removeDuration: const Duration(milliseconds: 400),
                            onReorder: onReorder,
                            onReorderStart: (index) =>
                                HapticFeedback.heavyImpact(),
                          )
                        : GridView.builder(
                            itemCount: _contacts.length,
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                    crossAxisSpacing: 50,
                                    mainAxisExtent: 280,
                                    maxCrossAxisExtent: 800),
                            itemBuilder: (context, index) {
                              final contact = _contacts[index];
                              return Container(
                                key: ValueKey(contact.id),
                                child: Center(
                                    child: ContactCard(contact: contact)),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
