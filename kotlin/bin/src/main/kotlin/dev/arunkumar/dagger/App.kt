package dev.arunkumar.dagger

import com.squareup.anvil.annotations.MergeComponent
import dagger.Component

@MergeComponent(AppScope::class)
interface AnvilComponent {
  @Component.Factory
  interface Factory {
    fun create(): AnvilComponent
  }
}

fun main() {
  DaggerAnvilComponent.factory()
    .create()
    .binding()
}
