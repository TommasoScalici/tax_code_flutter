package tommasoscalici.tax_code_flutter_wear_os

import android.os.Parcelable
import kotlinx.parcelize.Parcelize
import java.util.Date

@Parcelize
data class Contact(
    val id: String,
    val firstName: String,
    val lastName: String,
    val gender: String,
    val taxCode: String,
    val birthPlace: BirthPlace,
    val birthDate: Date,
    val listIndex: Int
) : Parcelable

@Parcelize
data class BirthPlace(
    val name: String,
    val state: String
) : Parcelable
