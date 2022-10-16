fn main() {
    println!("cargo:rustc-link-arg=--export-all");
    println!("cargo:rustc-link-arg=--global-base=1500000");
    println!("cargo:rustc-link-arg=-z,stack-size=1048576");
    println!("cargo:rustc-link-arg=--growable-table");
}
