
import sys
import os

os.system("npx love.js --title jelly_slicing jelly_slicing jelly_slicing_exported")
os.system("butler push jelly_slicing_exported/ thinkwithgames/jelly-slicing:web")
