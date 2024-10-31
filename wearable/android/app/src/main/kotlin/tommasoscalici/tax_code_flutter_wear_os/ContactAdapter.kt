package tommasoscalici.tax_code_flutter_wear_os

import android.content.Context
import android.util.Log
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.cardview.widget.CardView
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.color.MaterialColors
import io.flutter.plugin.common.MethodChannel
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Date

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
        Log.d(TAG, "Creating ViewHolder")
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_contact_card, parent, false)
        
        
        val typedValue = TypedValue()
        context.theme.resolveAttribute(android.R.attr.colorPrimary, typedValue, true)
        view.findViewById<CardView>(R.id.card_view).setCardBackgroundColor(typedValue.data)
        
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        Log.d(TAG, "Binding ViewHolder position: $position")
        val contact = contacts[position]
        val locale = context.resources.configuration.locales[0]
        
        with(holder) {
            
            taxCode.setTextColor(MaterialColors.getColor(
                context,
                com.google.android.material.R.attr.colorOnPrimary,
                android.graphics.Color.WHITE
            ))

            val valueTextColor = MaterialColors.getColor(
                context,
                com.google.android.material.R.attr.colorOnSurface,
                android.graphics.Color.WHITE
            )

            taxCode.text = contact.taxCode
            nameGender.apply {
                text = "${contact.firstName} ${contact.lastName} (${contact.gender})"
                setTextColor(valueTextColor)
            }
            birthPlace.apply {
                text = "${contact.birthPlace.name} (${contact.birthPlace.state})"
                setTextColor(valueTextColor)
            }
            birthDate.apply {
                text = DateFormat.getDateInstance(DateFormat.SHORT, locale)
                    .format(contact.birthDate)
                setTextColor(valueTextColor)
            }

            itemView.setOnClickListener {
                methodChannel.invokeMethod("openBarcodePage", contact.taxCode)
            }
        }
    }

    override fun getItemCount() = contacts.size

    fun updateContacts(newContacts: List<Contact>) {
        Log.d(TAG, "Updating contacts: ${newContacts.size}")
        contacts = newContacts
        notifyDataSetChanged()
    }
}