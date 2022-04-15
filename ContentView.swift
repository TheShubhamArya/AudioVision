import SwiftUI

struct NavigationViewController: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // do nothing
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = HomeVC()
        let navVC = UINavigationController(rootViewController: vc)
        return navVC
    }
}
