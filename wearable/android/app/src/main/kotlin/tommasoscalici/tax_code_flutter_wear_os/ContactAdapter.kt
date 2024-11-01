package tommasoscalici.tax_code_flutter_wear_os

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import io.flutter.plugin.common.MethodChannel
import java.text.DateFormat

class ContactAdapter(
    private val context: Context,
    private val methodChannel: MethodChannel
) : RecyclerView.Adapter<ContactAdapter.ViewHolder>() {
    private val TAG = "ContactAdapter"
    private var contacts: List<Contact> = emptyList()

    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val taxCode: TextView = view.findViewById(R.id.tax_code)
        val nameGender: TextView = view.findViewById(R.id.name_gender)
        val birthPlace: TextView = view.findViewById(R.id.birth_place)
        val birthDate: TextView = view.findViewById(R.id.birth_date)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_contact_card, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val contact = contacts[position]
        val locale = context.resources.configuration.locales[0]
        
        with(holder) {
            taxCode.text = contact.taxCode
            nameGender.text = "${contact.firstName} ${contact.lastName} (${contact.gender})"
            birthPlace.text = "${contact.birthPlace.name} (${contact.birthPlace.state})"
            birthDate.text = DateFormat.getDateInstance(DateFormat.SHORT, locale)
                .format(contact.birthDate)

            itemView.setOnClickListener {
                methodChannel.invokeMethod("openBarcodePage", contact.taxCode)
            }
        }
    }

    override fun getItemCount() = contacts.size

    fun updateContacts(newContacts: List<Contact>) {
        contacts = newContacts
        notifyDataSetChanged()
    }
}