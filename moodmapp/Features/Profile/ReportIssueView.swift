import SwiftUI

struct ReportIssueView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var issue: String = ""
  let viewModel: AuthViewModel
  let onComplete: (Bool) -> Void

  init(issue: String = "", viewModel: AuthViewModel, onComplete: @escaping (Bool) -> Void) {
    self._issue = State(initialValue: issue)
    self.viewModel = viewModel
    self.onComplete = onComplete
  }

  var body: some View {
    NavigationStack {
      Form {
        TextField("Tell us about it", text: $issue, axis: .vertical)
          .lineLimit(14, reservesSpace: true)
          .textInputAutocapitalization(.sentences)
      }
      .navigationTitle("Report an Issue")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            Task {
              let submission = await viewModel.reportAnIssue(issue.trimmingCharacters(in: .whitespacesAndNewlines))
              onComplete(submission)
              dismiss()
              
            }
          } label: {
            Text("Submit").font(.body.weight(.semibold))
          }
          .tint(.black)
          .disabled(issue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
    }
    .presentationDetents([.fraction(0.9)])
    .presentationDragIndicator(.visible)
  }
}
