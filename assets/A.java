 floatingActionButton: RawMaterialButton(
        onPressed: () {
          // Action here
        },
        elevation: 0.0,
        child: Image.asset(
          'assets/your_image.png',  // your full image here
          width: 56,                // size like default FAB
          height: 56,
        ),
        shape: const CircleBorder(),
        fillColor: Colors.transparent, // make background transparent
        constraints: BoxConstraints.tightFor(
          width: 56,
          height: 56,
        ),
      ),