import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["price", "borough", "fromDate", "toDate", "dateError", "submit"]
  static values = { monthOrderMessage: String }

  connect() {
    this.validateDates()
  }

  validateDates() {
    const from = this.fromDateTarget.value
    const to = this.toDateTarget.value
    const reversed = Boolean(from && to && from > to)

    this.fromDateTarget.max = to
    this.toDateTarget.min = from
    this.fromDateTarget.setCustomValidity(reversed ? this.monthOrderMessageValue : "")
    this.dateErrorTarget.classList.toggle("d-none", !reversed)

    return !reversed
  }

  useExample() {
    this.priceTarget.value = "100000"
    this.boroughTarget.value = "Islington"
    this.fromDateTarget.value = "2000-01"
    this.toDateTarget.value = "2016-01"
    this.validateDates()
    this.priceTarget.focus()
  }

  submitting(event) {
    if (!this.validateDates()) {
      event.preventDefault()
      return
    }

    this.submitTarget.disabled = true
    this.submitTarget.textContent = "Calculating…"
  }
}
