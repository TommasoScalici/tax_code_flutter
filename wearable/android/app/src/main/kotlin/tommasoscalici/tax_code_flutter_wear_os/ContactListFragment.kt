package tommasoscalici.tax_code_flutter_wear_os

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.HapticFeedbackConstants
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.cardview.widget.CardView
import androidx.fragment.app.Fragment
import androidx.wear.widget.CircularProgressLayout
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ContactListFragment : Fragment() {
    private var _contactsContainer: LinearLayout? = null
    private var _contactsScrollView: ScrollView? = null
    private var _circularProgress: CircularProgressLayout? = null
    
    private val contactsContainer get() = _contactsContainer!!
    private val contactsScrollView get() = _contactsScrollView!!
    private val circularProgress get() = _circularProgress!!
    
    private val simpleDateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.getDefault())

    companion object {
        fun newInstance(contacts: ArrayList<HashMap<String, Any>>?): ContactListFragment {
            return ContactListFragment().apply {
                arguments = Bundle().apply {
                    putSerializable("contacts", contacts)
                }
            }
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val hasContacts = arguments?.getSerializable("contacts") != null
        val layoutRes = if (hasContacts) {
            R.layout.fragment_contact_list
        } else {
            R.layout.empty_contact_list
        }
        
        return inflater.inflate(layoutRes, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupViews(view)
        loadContacts()
    }

    private fun setupViews(view: View) {
        val hasContacts = arguments?.getSerializable("contacts") != null
        
        if (hasContacts) {
            _contactsScrollView = view.findViewById(R.id.scroll_view)
            _circularProgress = view.findViewById(R.id.circular_progress)
            _contactsContainer = view.findViewById(R.id.contacts_container)
            
            contactsScrollView.apply {
                requestFocus()
                isVerticalScrollBarEnabled = true
            }
        } else {
            setupEmptyState(view)
        }
    }

    private fun setupEmptyState(view: View) {
        val isItalian = Locale.getDefault().language == "it"
        
        view.findViewById<TextView>(R.id.empty_message)?.apply {
            text = if (isItalian) {
                "Nessun contatto trovato, aggiungi prima un contatto da smartphone per visualizzare qui la lista."
            } else {
                "No contacts found, you must add one first from your smartphone to see here the list."
            }
        }

        view.findViewById<TextView>(R.id.phone_button_text)?.apply {
            text = if (isItalian) {
                "Apri sul telefono"
            } else {
                "Open on phone"
            }
        }

        view.findViewById<CardView>(R.id.phone_button_card)?.apply {
            setOnClickListener { v ->
                v.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
            }
        }
    }

    private fun loadContacts() {
        val contactsData = arguments?.getSerializable("contacts") as? ArrayList<HashMap<String, Any>>

        contactsData?.let { data ->
            data.forEach { map ->
                try {
                    val contact = Contact(
                        id = map["id"] as String,
                        firstName = map["firstName"] as String,
                        lastName = map["lastName"] as String,
                        gender = map["gender"] as String,
                        taxCode = map["taxCode"] as String,
                        birthPlace = BirthPlace(
                            name = (map["birthPlace"] as Map<*, *>)["name"] as String,
                            state = (map["birthPlace"] as Map<*, *>)["state"] as String
                        ),
                        birthDate = simpleDateFormat.parse(map["birthDate"] as String) ?: Date(),
                        listIndex = (map["listIndex"] as Number).toInt()
                    )
                    addContactView(contact)
                } catch (e: Exception) {
                    Log.e("ContactListFragment", "Error mapping contact: $e")
                }
            }
        }
    }

    private fun addContactView(contact: Contact) {
        val contactView = LayoutInflater.from(requireContext())
            .inflate(R.layout.item_contact_card, contactsContainer, false)

        with(contactView) {
            findViewById<TextView>(R.id.tax_code)?.text = contact.taxCode
            findViewById<TextView>(R.id.name_gender)?.text = 
                "${contact.firstName} ${contact.lastName} (${contact.gender})"
            findViewById<TextView>(R.id.birth_place)?.text = 
                "${contact.birthPlace.name} (${contact.birthPlace.state})"
            findViewById<TextView>(R.id.birth_date)?.text = 
                DateFormat.getDateInstance(DateFormat.MEDIUM, Locale.getDefault())
                    .format(contact.birthDate)

            setOnClickListener {
                it.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
                openBarcodeFragment(contact.taxCode)
            }
        }

        _contactsContainer?.addView(contactView)
    }

    private fun openBarcodeFragment(taxCode: String) {
        parentFragmentManager.beginTransaction()
            .add(android.R.id.content, BarcodeFragment.newInstance(taxCode))
            .addToBackStack(null)
            .commit()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _contactsContainer = null
        _contactsScrollView = null
        _circularProgress = null
    }
}