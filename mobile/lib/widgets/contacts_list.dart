import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';

import 'contact_card.dart';

final class ContactsList extends StatefulWidget {
  const ContactsList({super.key});

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  final _searchTextEditingController = TextEditingController();
  List<Contact> _filteredContacts = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
  }

  void _filterContacts(String searchText, List<Contact> allContacts) {
    final appState = context.read<AppState>();
    appState.setSearchState(searchText.isNotEmpty);

    setState(() {
      _searchText = searchText;
      _filteredContacts = allContacts
          .where((c) =>
              c.taxCode.toLowerCase().contains(searchText.toLowerCase()) ||
              c.firstName.toLowerCase().contains(searchText.toLowerCase()) ||
              c.lastName.toLowerCase().contains(searchText.toLowerCase()) ||
              c.birthPlace.name
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void _onReorder(int oldIndex, int newIndex, AppState appState) {
    HapticFeedback.lightImpact();
    final contacts = appState.contacts;

    final contact = contacts.removeAt(oldIndex);
    contacts.insert(newIndex, contact);

    for (int i = 0; i < contacts.length; i++) {
      contacts[i].listIndex = i;
    }

    appState.updateContacts(contacts);
    appState.saveContacts();
  }

  Widget _buildSearchField(AppState appState) {
    return SizedBox(
      width: 400,
      child: TextField(
        autocorrect: false,
        controller: _searchTextEditingController,
        onChanged: (searchText) =>
            _filterContacts(searchText, appState.contacts),
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: AppLocalizations.of(context)!.search,
            suffix: IconButton(
                onPressed: () {
                  _searchTextEditingController.clear();
                  _filterContacts('', appState.contacts);
                  FocusScope.of(context).unfocus();
                },
                icon: const Icon(Icons.clear))),
      ),
    );
  }

  Widget _buildContactsGrid(List<Contact> contacts, AppState appState) {
    final isReorderable = _searchText.isEmpty;

    if (isReorderable) {
      return AnimatedReorderableGridView(
        items: contacts,
        sliverGridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          crossAxisSpacing: 50,
          mainAxisExtent: 280,
          maxCrossAxisExtent: 800,
        ),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final contact = contacts[index];
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
        onReorder: (oldIndex, newIndex) =>
            _onReorder(oldIndex, newIndex, appState),
        onReorderStart: (index) => HapticFeedback.heavyImpact(),
        isSameItem: (Contact a, Contact b) => a.id == b.id,
      );
    }

    return GridView.builder(
      itemCount: contacts.length,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        crossAxisSpacing: 50,
        mainAxisExtent: 280,
        maxCrossAxisExtent: 800,
      ),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Container(
          key: ValueKey(contact.id),
          child: Center(child: ContactCard(contact: contact)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final contactsToShow =
            _searchText.isEmpty ? appState.contacts : _filteredContacts;

        // Show a message if the list is empty and the user is not searching.
        if (contactsToShow.isEmpty && _searchText.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noContactsFound,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 90.0),
          child: Center(
            child: Column(
              children: [
                _buildSearchField(appState),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: _buildContactsGrid(contactsToShow, appState),
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
