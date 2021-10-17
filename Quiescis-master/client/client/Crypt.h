#ifndef CRYPT_H
#define CRYPT_H

// To encrypt a file using the XOR method
std::string CryptFile(std::string path, int key);
// To encrypt a directory using the XOR method
std::string CryptDir(std::string path, int key);

// For full file reading
std::string readFile(const std::string fileName);

#endif // CRYPT_H